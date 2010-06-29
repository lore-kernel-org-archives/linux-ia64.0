From: "Bob Zhang" <bob_zhang2004@tom.com>
Date: Tue, 29 Jun 2010 14:30:03 +0000
Subject: Re: [bug report ] hp's rx2860 (kernel is 2.6.27.19-5 in sles11 ia64)
Message-Id: <op.ve2fwdvf8m5662@bob-pc>
List-Id: <linux-ia64.vger.kernel.org>
References: <201006242333018701088@tom.com>
 <AANLkTinT8YMKGw3obdbIMINkUGNUgfUQEOEzgHMOPOtt@mail.gmail.com>
In-Reply-To: <AANLkTinT8YMKGw3obdbIMINkUGNUgfUQEOEzgHMOPOtt@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: "len.brown" <len.brown@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-acpi <linux-acpi@vger.kernel.org>

I finally found "S5" definition , details can got from my following reply.
Next step, I will send this information to firmware engineer to verify
SSDT17.dsl is right for our sentosa. Because same values into registers  
every
time, but got different hardware behaviors.
So we must doubt hardware and firmware design.
Now, from software point of view : acpi_enter_sleep_state() is the last
function to run when shutdown machine , which write value into acpi  
registers
to tell hardware to enter S5 (SLP_TYPx and SLP_EN)  .Once written to these  
two
registers, software task has been over. The left things are hardware is to
work. So I think Linux kernel is good, this issue is from related with
kernel,at acpi driver's logic is right. I have printed values which will be
written to acpi registers , those values are the same every time, but  
hardware
has different behaviors , so we need firmware engineer to help me check .

Maybe I need to ask firmware designer what is the meaning of this  
definition:
Where is {0x7,0x7} from ?? which datasheet ? which document ?
In "SSDT17.dsl" .
DefinitionBlock ("SSDT17.aml", "SSDT", 2, "HP    ", "RX2800-2", 0x00000007)
{
     Scope (\)
     {
         Name (\_S5, Package (0x03)
         {
             0x07,
             0x07,
             Zero
         })
     }
This is equal of that return from acpi_get_sleep_type_data(5,&type_a,  
&type_b)

