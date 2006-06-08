From: "vamsi krishna" <vamsi.krishnak@gmail.com>
Date: Thu, 08 Jun 2006 20:59:02 +0000
Subject: Re: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <3faf05680606081347s7c24a13bpcf0945981a54d9ed@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Matt,

Thank you,

> > Do you mean file descriptors?
>
> No.  A function descriptor is sometimes called a 'fat pointer'.
> Function pointers on ia64 (as with ppc64 and parisc) are not pointers to

If the memory of the fat pointers is there on the heap or mmaped some
where in the mmap space I already take care that , I remap them with
the same address in restore run.

I save all the maps during my save run (including the text of dynamic
shared objects, I dont save the STACK) and mmap them back when I start
my program back.

I only thing (map) I did'nt save during the save run is STACK segment,
so if I leave the STACK segment as it is in the restore run and just
overwrite the RES backstore area then I see that variable on the
current stack are getting corrupted, Is it because that RES backstore
also have some information about the stack ?

Can I slice up RES backstore area avoiding overwriting of the register
information?

My program is a little different from unexec because it tries to
change itself on the fly by writing into its own address space........

The code works on all other linux kernels  except one on IA64...:((

Your suggestions are greatly appreciated .

Sincerely,
Vamsi.
