From: Andrew Morton <akpm@osdl.org>
Date: Sat, 18 Oct 2003 01:41:11 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106644129923832@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt Chapman <matthewc@cse.unsw.edu.au> wrote:
>
> It *does* signal a fault, in the form of a machine check.  On other
>  architectures I'm familiar with this is usually implemented as an
>  interrupt, but the idea is similar - when the system bus controller
>  detects a bad address on the bus, it returns all 1s (for a read) and
>  signals an interrupt.

I see.  That seems OK.  At least it means that software can implement a
probing function and that the time interval between hot unplug and handling
the unplug interrupt can be managed appropriately.


