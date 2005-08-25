From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 25 Aug 2005 23:52:17 +0000
Subject: RE: Allow /proc/pal/cpu0/vm_info under the simulator
Message-Id: <17166.22961.538721.805817@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17165.4305.205911.684685@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17165.4305.205911.684685@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

>> - if (ia64_pal_mem_attrib(&attrib) != 0) - return 0; + if
>> (ia64_pal_mem_attrib(&attrib) != 0){ + *p++ = '\n'; + return
>> p-page; + }

Tony> Could we be even more tolerant with a series (gasp) goto
Tony> statements instead of the "return"?  Like this:

Tony> 	if (ia64_pal_mem_attrib(&attrib) != 0) goto skip_mem_attrib;

Tony> 	... code to print things in &attrib

Tony> skip_mem_attrib:


Tony> This would require a bit more re-arranging of the code to make
Tony> all the uses of each PAL call fall right after the call.


Can do... Give me a while to whip up and test a patch...

PeterC 
