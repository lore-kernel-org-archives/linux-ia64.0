From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 23 Aug 2001 16:17:44 +0000
Subject: Re: [Linux-ia64] mca messages
Message-Id: <marc-linux-ia64-105590698805099@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805098@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Thu, Aug 23, 2001 at 10:29:48AM -0500, Van Maren, Kevin wrote:
> Running 2.4.8+patch on a 4X Lion, I got a bunch of these:
> 
>     ia64_mca_cpe_int_handler : received interrupt. vector = 0x1e
>     ia64_log_get : Failed to retrieve SAL error record type 3
> 
> The VGA went quite wacky on my as well: those two lines were
> flickering on top of each other in the VTs.  If I <returned>
> to scroll down, the lines at the bottom were normal, but the
> lines above still had both lines flickering on top of each other.
> When I changed VTs, the lines reappeared on the screen.
> 
> Anyone know what is up?
> 

I was told that you need a very recent version of the firmware to 
get the MCA support to work. For the server machines, build 86B
is just not good enough. You need to disable that option until
you install a newer version of the FW becomes available. I have
not yet tried this on the workstations. So turn off CONFIG_IA64_MCA for now.

-- 
-Stephane

