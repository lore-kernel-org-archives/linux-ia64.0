From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 14 Mar 2003 16:52:15 +0000
Subject: Re: [Linux-ia64] How to set/reset gp pointer : info needed
Message-Id: <marc-linux-ia64-105590709806099@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806096@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806096@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Raj,

Take a look at the software calling convention document at:

http://developer.intel.com/design/itanium/downloads/245358.htm



On Fri, Mar 14, 2003 at 07:08:51AM -0800, Raj Patil wrote:
> 
> Hello,
> 
> I am not sure whether this is the right group for me to ask this or get the
> 
> kind of information I am looking for. I apologize if this is not the
> 
> right group. I am relatively new to Linux/ia64 and this question is related
> 
> to ia64. Hence, decided to post it here 
> 
> I am looking for some info on how to set/unset the gp pointer, locations/cases
> 
> where I need to set and any other issues I need to worry. Any pointers to
> 
> some documentation or sample code or notes will be really appreciated.
> 
> Reason: I am just trying to port an utility to ia64 based Linux platform from 
> 
> x86 platform. It adds an entry to syscall table to point to a function in 
> 
> a module. It is like adding a new temp syscall for a small duration. 
> 
> By looking at some documentation, I realized that I need to set 
> 
> the gp pointer correctly before calling the function (not sure exactly wehre
> 
> and how). So, I am looking for some docs/notes which clarify my doubts like
> 
> -what in general needs to be done to set/reset gp (where?).
> 
> -Does this need to be done if one is adding an entry to ia32 syscall 
> 
> table too? 
> 
> -If this new function in the module calls other kernel functions in between,
> 
> should it worry about gp pointer before calling the kernel functions etc.
> 
> I have access to RH Advanced Server 2.1 running on an HP Itanium-2 box.
> 
> Thank you very much for any pointers/info.
> 
> Regards,
> 
> Raj
> 
> 
> 
> ---------------------------------
> Do you Yahoo!?
> Yahoo! Web Hosting - establish your business online
-- 

-Stephane

