From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Sun, 13 Oct 2002 23:39:05 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.39)
Message-Id: <marc-linux-ia64-105590709805156@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jes" = Jes Sorensen <jes@trained-monkey.org> writes:

Jes> David Mosberger <davidm@napali.hpl.hp.com> writes:
>> >>>>> On Tue, 1 Oct 2002 09:28:12 +1000, Peter Chubb
>> <peter@chubb.wattle.id.au> said:
>> 
Peter> 1.  Change the definition of ino_t to be a long, not an int, as
Peter> was done in the sparc64 and ppc64 code.  The comments in
Peter> asm/posix_types.h say these types are used for communication to
Peter> userspace, so maybe that's not an option any more?
>> [snip]
>> 
>> If we can do it without breaking apps, I'm all for changing ino_t
>> to 64 bits.  Note that "struct stat" already defines the st_ino
>> member as "unsigned long".  Also, glibc declares ino_t as a 64-bit
>> type.

Looks like this is now a non-issue:

ChangeSet@1.785.1.1, 2002-10-12 12:09:25-07:00,
rth@splat.sfbay.redhat.com
  Fix warnings of the form
    warning: long int format, different type arg (arg 5)
  by casting ino_t arguments to unsigned long for printf formats.
  In some instances, change %ld to %lu.

Peter C

