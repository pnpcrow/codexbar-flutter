#!/usr/bin/env python3
"""Chrome cookie decryptor for CodexBar Flutter.
Reads and decrypts cookies from Chrome's SQLite database on Linux.

Usage: python3 chrome_cookie_decryptor.py <domain> [cookie_name1,cookie_name2,...]

Output format (one per line): name=value
If no cookie names specified, returns all cookies for the domain.
"""

import sys
import sqlite3
import os
import hashlib
import tempfile
import shutil

def get_chrome_key():
    """Get Chrome encryption key from GNOME Keyring."""
    try:
        import gi
        gi.require_version('Secret', '1')
        from gi.repository import Secret

        schema = Secret.Schema.new(
            'chrome_libsecret_os_crypt_password_v2',
            Secret.SchemaFlags.NONE,
            {}
        )
        items = Secret.password_search_sync(schema, {}, Secret.SearchFlags.ALL, None)

        for item in items:
            if item.get_label() == 'Chrome Safe Storage':
                item.load_secret_sync(None)
                s = item.get_secret()
                if s:
                    return s.get_text()
    except Exception:
        pass

    # Fallback: default password
    return 'peanuts'


def derive_key(password):
    """Derive AES key from password using PBKDF2."""
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    from cryptography.hazmat.primitives.hashes import SHA1

    kdf = PBKDF2HMAC(
        algorithm=SHA1(),
        iterations=1,
        length=16,
        salt=b'saltysalt'
    )
    return kdf.derive(password.encode('utf-8'))


def decrypt_cookie(encrypted_value, enc_key, db_version):
    """Decrypt a Chrome cookie value."""
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

    if not encrypted_value or len(encrypted_value) < 4:
        return None

    prefix = encrypted_value[:3]
    if prefix not in (b'v10', b'v11'):
        return None

    # Strip v10/v11 prefix
    encrypted = encrypted_value[3:]

    # AES-128-CBC with IV = 16 spaces
    init_vector = b' ' * 16
    cipher = Cipher(algorithms.AES(enc_key), modes.CBC(init_vector))
    decryptor = cipher.decryptor()
    decrypted = decryptor.update(encrypted) + decryptor.finalize()

    # Remove PKCS7 padding
    pad_len = decrypted[-1]
    if isinstance(pad_len, int) and 1 <= pad_len <= 16:
        decrypted = decrypted[:-pad_len]

    # For v24+, strip 32-byte SHA256 hash from the beginning
    if db_version >= 24 and len(decrypted) > 32:
        decrypted = decrypted[32:]

    try:
        return decrypted.decode('utf-8')
    except UnicodeDecodeError:
        return None


def read_cookies(domain, cookie_names=None):
    """Read and decrypt cookies for a domain from Chrome."""
    db_path = os.path.expanduser('~/.config/google-chrome/Default/Cookies')
    if not os.path.exists(db_path):
        return []

    # Copy DB to temp (Chrome locks it)
    tmp_db = tempfile.mktemp(suffix='.db')
    try:
        shutil.copy2(db_path, tmp_db)
    except Exception:
        return []

    try:
        conn = sqlite3.connect(f'file:{tmp_db}?mode=ro', uri=True)
        conn.text_factory = bytes

        # Get DB version
        try:
            row = conn.execute("select value from meta where key = 'version'").fetchone()
            db_version = int(row[0]) if row else 0
        except Exception:
            db_version = 0

        # Get Chrome key
        password = get_chrome_key()
        enc_key = derive_key(password)

        # Query cookies - match domain in host_key (e.g. .xiaomimimo.com)
        domain_pattern = '%' + domain + '%'
        cursor = conn.cursor()

        if cookie_names:
            results = []
            for name in cookie_names:
                cursor.execute(
                    "SELECT name, value, encrypted_value FROM cookies "
                    "WHERE host_key LIKE ? AND name = ?",
                    (domain_pattern, name)
                )
                for row in cursor.fetchall():
                    cname, cvalue, enc_val = row
                    cname = cname.decode('utf-8') if isinstance(cname, bytes) else cname
                    cvalue = cvalue.decode('utf-8') if isinstance(cvalue, bytes) else cvalue

                    if cvalue:
                        results.append((cname, cvalue))
                    elif enc_val:
                        decrypted = decrypt_cookie(enc_val, enc_key, db_version)
                        if decrypted:
                            results.append((cname, decrypted))
            return results
        else:
            cursor.execute(
                "SELECT name, value, encrypted_value FROM cookies "
                "WHERE host_key LIKE ?",
                (domain_pattern,)
            )
            results = []
            for row in cursor.fetchall():
                cname, cvalue, enc_val = row
                cname = cname.decode('utf-8') if isinstance(cname, bytes) else cname
                cvalue = cvalue.decode('utf-8') if isinstance(cvalue, bytes) else cvalue

                if cvalue:
                    results.append((cname, cvalue))
                elif enc_val:
                    decrypted = decrypt_cookie(enc_val, enc_key, db_version)
                    if decrypted:
                        results.append((cname, decrypted))
            return results

    finally:
        conn.close()
        try:
            os.unlink(tmp_db)
        except Exception:
            pass


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: chrome_cookie_decryptor.py <domain> [cookie_names]", file=sys.stderr)
        sys.exit(1)

    domain = sys.argv[1]
    cookie_names = sys.argv[2].split(',') if len(sys.argv) > 2 else None

    cookies = read_cookies(domain, cookie_names)
    for name, value in cookies:
        print(f'{name}={value}')
