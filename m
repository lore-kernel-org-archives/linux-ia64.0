From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 07 Dec 2004 15:04:14 +0000
Subject: Re: CPU hot-remove - Handoff Processor to SAL
Message-Id: <20041207150414.GF10881@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041206220159.A7973@unix-os.sc.intel.com>
In-Reply-To: <20041206220159.A7973@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 06, 2004 at 10:01:59PM -0800, Ashok Raj wrote:
> @@ -609,8 +643,10 @@ void __cpu_die(unsigned int cpu)
>  			 * TBD: Enable this when physical removal
>  			 * or when we put the processor is put in
>  			 * SAL_BOOT_RENDEZ mode
> -			 * cpu_clear(cpu, cpu_callin_map);
> +			 cpu_clear(cpu, cpu_callin_map);
> +			 printk ("Clearing cpu_callin_map\n");
>  			 */
> +			printk ("Now cpu %d is dead\n", cpu);
>  			return;
>  		}
>  		current->state = TASK_UNINTERRUPTIBLE;

Is this just a debugging printk?  I wouldn't be too happy if a customer
sees the message "Now cpu 3 is dead" in their logs.  I can almost hear
the terrified support call now ...

"I asked the machine to take the CPU offline and now it's dead!  My boss
is going to kill me!"

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
