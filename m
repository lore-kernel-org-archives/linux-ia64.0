From: Valdis.Kletnieks@vt.edu
Date: Tue, 20 May 2003 20:30:01 +0000
Subject: [Linux-ia64] Re: /proc/kcore - how to fix it
MIME-Version: 1
Content-Type: multipart/mixed; boundary="==_Exmh_1928944008P"
Message-Id: <marc-linux-ia64-105590723705961@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--==_Exmh_1928944008P
Content-Type: text/plain; charset=us-ascii

On Tue, 20 May 2003 13:05:15 PDT, "Luck, Tony" said:

> What about discontiguous memory.  Since /proc/kcore is super-user only
> we could continue with the attitude that the user should be careful not
> to touch memory that doesn't exist, or we could be kind and provide an
> API so that the architecture specific code that finds the memory can tell
> /proc/kcore what exists.

"don't touch memory that doesn't exist" is a bad idea unless there is *some*
sort of API that allows the program to intuit what does/doesn't exist.  If
the program can't find out what is legal without hitting an oops or worse,
nobody will use /proc/kcore, and then why bother implementing it?

(Note that I'd consider "look *here* for a pointer to known-existing memory,
then look 24 bytes into there for a pointer to a linked list of memory
block address/size pairs" sufficient, no need for a fancy /proc interface.
Of course, that's just my opinion - those who don't have memories of
pointer chasing in S/360 assembler under OS/MVT may have other opinions ;)

--==_Exmh_1928944008P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE+ypBIcC3lWbTT17ARAq1KAJ4o/hjlZcsI9Tv9LBpvY9zxbwhO/QCbBoZo
EBcJ1g8p6RFULfWBxzh0/vk=
=uCNH
-----END PGP SIGNATURE-----

--==_Exmh_1928944008P--

