From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Sat, 23 Aug 2003 04:27:15 +0000
Subject: selinux build failure
Message-Id: <marc-linux-ia64-106161286205885@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

selinux/hooks.c won't build on ia64.
2.6.0-test3 + ia64 patch or 2.6.0-test4.

security/selinux/hooks.c: In function `selinux_file_fcntl':
security/selinux/hooks.c:2032: error: `F_GETLK64' undeclared (first use in
this function) security/selinux/hooks.c:2033: error: `F_SETLK64' undeclared
(first use in this function) security/selinux/hooks.c:2034: error:
`F_SETLKW64' undeclared (first use in this function)

The __64 versions of these are defined in include/asm-ia64/compat.h. I don't
see a good way to #include asm/compat.h, nor is it available for all
processor architectures.

~Randy



