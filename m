From: Ashok Raj <ashok.raj@intel.com>
Date: Thu, 03 Nov 2005 21:06:09 +0000
Subject: Re: Probing for physical number of cpus.
Message-Id: <20051103130609.A30148@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510281318.51532.Roy.Dragseth@cc.uit.no>
In-Reply-To: <200510281318.51532.Roy.Dragseth@cc.uit.no>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 03, 2005 at 12:10:34AM -0800, Roy Dragseth wrote:
> 
>    On Friday 28 October 2005 14:43, Andreas Schwab wrote:
>    > Roy Dragseth <Roy.Dragseth@cc.uit.no> writes:
>    > > Do anyone know how to figure out the physical number of cpus in an
>    ia64
>    >  >  system?   No, /proc/cpuinfo wont do because the kernel is booted
>    with
>    > > maxcpus=1.
>    >
>    >  Read  and  parse the ACPI tables off of /dev/mem, starting with the
>    address
>    > from /sys/firmware/efi/systab.
> 
>    Yikes!    Thanks  for  the  answer.   I've  been  toying  around  with
>    pmtools/acpidump
>    which  gives  me a text dump, but I'm still a bit confused (to say the
>    least).
> 

Actually even of you boot with maxcpus=1, we still create sysfs entries for
each cpus physically present in the system.

you should be able to look at /sys/devices/system/cpu/cpuX entries

if you compiled with CONFIG_HOTPLUG_CPU enabled, then you could
echo 1 > online file in the appropriate cpu directory to add more 
cpus.

Let me know if you dont see this behaviour.

Cheers,
ashok
