From: "vamsi krishna" <vamsi.krishnak@gmail.com>
Date: Thu, 08 Jun 2006 09:51:49 +0000
Subject: Re: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <3faf05680606080239v61e315ffx6462ba08e23a11d7@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Andreas,

On 6/8/06, Andreas Schwab <schwab@suse.de> wrote:
> "vamsi krishna" <vamsi.krishnak@gmail.com> writes:
>
> > Looks like If I dont overwrite the RSE backing store fclose on my open
> > files seem to crash when I restore my program.
>
> You also need to make sure that all function descriptors end up at the
> very same address.
>

More to add to this I found that '__IO_flush_all' seem to get stuck ,
when I dont overwrite my RSE backing store, if I overwrite my RSE
backing store some of the data on the stack is getting corrupted.

is '__IO_flush_all' a weak symbol so that I can override ? also
fflush(NULL) hangs and also fcloseall() (I think all are calling
__IO_flush_all)

In my program to restore the state just as emacs unexec I try to save
all the mmaps and either overwrite (for heap) or mmap for all the
things above &_etext.

I tried to save all the maps in /proc/pid/maps except the RSE backing
store and it seems problems in __IO_flush_all , I also made sure that
I flushed all my filestreams before I save.


Really appreciate your comments, let me know if you need more info.

Thank you,
Vamsi
