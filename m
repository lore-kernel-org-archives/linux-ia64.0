From: Keith Owens <kaos@sgi.com>
Date: Sat, 28 Feb 2004 23:59:30 +0000
Subject: Re: Oops in pdflush
Message-Id: <30132.1078012770@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 28 Feb 2004 10:26:18 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Sat, 28 Feb 2004 15:55:37 +0100, Andreas Schwab <schwab@suse.de> said:
>
>  Andreas> David Mosberger <davidm@napali.hpl.hp.com> writes:
>
>  >> Say, Andreas, did you by chance have 3 disk drives in your Tiger?
>
>  Andreas> No, only one.
>
>Hmmh, kind of throws that theory out of the water...
>
>I still don't understand why the problem triggered only on certain
>machine.

pdflush threads are per filesystem, independent of the number of
physical disks.  When you have concurrent heavy I/O load against more
than MIN_PDFLUSH_THREADS filesystems, pdflush will detect that all its
worker tasks are in use and will fork new tasks.

