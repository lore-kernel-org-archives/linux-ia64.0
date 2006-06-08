From: "vamsi krishna" <vamsi.krishnak@gmail.com>
Date: Thu, 08 Jun 2006 00:29:58 +0000
Subject: Re: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <3faf05680606071717m65954db1w440a321aa3b9ded8@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Tony,

>
> RSE backing store.

Can you tell me where I can find more information about  this?

>
> > Also why IPF kernel differs from other systems where the mmap space is
> > below &_etext where as on other systems its above &_end. ??
>
> Do you have an application where this is a problem?
>

My application is similar to unexec of emacs, tries to save all the
segments in the map file and restore them back, while restoring
currently we assume that if the segment is above sbrk(0) then it needs
to be mmap'ed from the save file else override it.


Looks like If I dont overwrite the RSE backing store fclose on my open
files seem to crash when I restore my program.
