From: umut aymakoglu <umutaymak@yahoo.com>
Date: Wed, 24 Dec 2003 23:13:13 +0000
Subject: segv at strcmp
Message-Id: <marc-linux-ia64-107230762310061@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi -

We have hit a problem with strcmp() on UnitedLinux 1.0
with kernel: 2.4.19 and glibc: 2.2.5.
I am wondering if anybody has seen something like it
or knows if already there is a patch. I do not have a
small repro but i will try to explain:

The segv happens at memcmp() at a line like:
'strcmp(x, "this is 24 chars long")' where x is a char
pointer with a length of 7 and the constant has a
length of 24. x is located at the first 8 bytes of the
last 16 bytes at the end of a non-contiguous shared
memory segment. memcmp() segvs when it tries to load 8
bytes from the "r19" register which initially has the
address of x and points to the end of the segment when
the segv happens.

any help would be appreciated,
thanks,
Umut 


__________________________________
Do you Yahoo!?
New Yahoo! Photos - easier uploading and sharing.
http://photos.yahoo.com/
