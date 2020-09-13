From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 13 Sep 2020 19:51:13 +0000
Subject: vmlinux link failure on ia64 with zstd
Message-Id: <f0a93b2d435252b3878ce821142677754f5e434c.camel@decadent.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-R1VkkNmnIse0QTyxO5M/"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-R1VkkNmnIse0QTyxO5M/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Enabling CONFIG_RD_ZSTD (which is enabled by default) resulted in a
link failure on ia64:

+ ld -r -o vmlinux.o --whole-archive arch/ia64/kernel/head.o init/built-in.=
a usr/built-in.a arch/ia64/kernel/built-in.a arch/ia64/mm/built-in.a kernel=
/built-in.a certs/built-in.a mm/built-in.a fs/built-in.a ipc/built-in.a sec=
urity/built-in.a crypto/built-in.a block/built-in.a lib/built-in.a arch/ia6=
4/lib/built-in.a lib/lib.a arch/ia64/lib/lib.a drivers/built-in.a sound/bui=
lt-in.a net/built-in.a virt/built-in.a arch/ia64/pci/built-in.a arch/ia64/h=
p/common/built-in.a --no-whole-archive --start-group --end-group
ld: lib/zstd/entropy_common.o: linking constant-gp files with non-constant-=
gp files
ld: failed to merge target specific data of file lib/zstd/entropy_common.o
ld: lib/zstd/fse_decompress.o: linking constant-gp files with non-constant-=
gp files
ld: failed to merge target specific data of file lib/zstd/fse_decompress.o
ld: lib/zstd/zstd_common.o: linking constant-gp files with non-constant-gp =
files
ld: failed to merge target specific data of file lib/zstd/zstd_common.o

This is seen on Debian unstable, with gcc 10.2 and binutils 2.35.  A
full build log is available at:
https://buildd.debian.org/status/fetch.php?pkg=3Dlinux&arch=3Dia64&ver=3D5.=
9~rc4-1~exp1&stamp=3D1599955166&raw=3D1

Ben.

--=20
Ben Hutchings
Humour is the best antidote to reality.


--=-R1VkkNmnIse0QTyxO5M/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAl9eeDIACgkQ57/I7JWG
EQkYAA/9GO3g4U7D4jY2QZKplQclmeu2SQWQpa//cNho69C3NLLq0XFCtTzFxIhJ
4PQIo7CThVghLOOUuEahDTwQe6xrI9JQOr0rcHs3qKbJGSa0InP+0psi7M5O6faZ
9qn04cHN1cLThmIBenh4m/E/5oFArCTSy8e8hCU+2wy7rLKcTbd3JeUghbQ4hXBn
KKqGk4wRWI4kNtcxNKLxVVSrqLd9NVcUze/9wPdXkXnzIZV3+Adv5Q8LodnOBhkf
q2GTzzFVgvam24hdBxBg3WnkGUTESphw4LUlXJGyFIl8WDBEP/muTE/3snA/HrMQ
YFMEuXS/uKJVTmqKSarjumlI6ObR+kXB7TKG74a4fpU3p9vHwYyWK1lPLguESlmf
Bfe2KT1PU7FepwlEDXCqIwBxDqDTDWKdyqEB0XuT+Uu79JfBV+i3c5fKf9FwzzlJ
pf0x4idFnDzDm+UsMtxLx7O4ZFziO7KQadZ8KnZrq0l3qdRdsydZpvWCyoYy9qDz
E8VTzuQAqmOO7Oo6IwuSBzxaNK2qTtzSAGC81I0sZQvZcNQCq8N91T51VVQQzps0
Bbjk73dXsOeEQC9uRxDnJqaCeGQeISVxeVMb5UfIMjqXNwRLjdbg176hESBzlhfw
YxTTPeULfEwWz/kbh4DS42ZNoZuou+S751rs0/WmPbDPy4qjHZk=
=BRRp
-----END PGP SIGNATURE-----

--=-R1VkkNmnIse0QTyxO5M/--
