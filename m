From: Jes Sorensen <jes@trained-monkey.org>
Date: Thu, 17 Oct 2002 11:46:40 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.39)
Message-Id: <marc-linux-ia64-105590709805180@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:

>>>>> "Jes" = Jes Sorensen <jes@trained-monkey.org> writes:
>>> If we can do it without breaking apps, I'm all for changing ino_t to
>>> 64 bits.  Note that "struct stat" already defines the st_ino member
>>> as "unsigned long".  Also, glibc declares ino_t as a 64-bit type.

Peter> Looks like this is now a non-issue:

This is probably the least of the problem (if there is one), compiler
warnings for print's don't matter all that much.

Jes

