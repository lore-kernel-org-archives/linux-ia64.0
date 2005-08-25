From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 25 Aug 2005 23:36:47 +0000
Subject: RE: Allow /proc/pal/cpu0/vm_info under the simulator
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F043B9E34@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17165.4305.205911.684685@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17165.4305.205911.684685@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>-	if (ia64_pal_mem_attrib(&attrib) != 0)
>-		return 0;
>+	if (ia64_pal_mem_attrib(&attrib) != 0){
>+		*p++ = '\n';
>+		return p-page;
>+	}

Could we be even more tolerant with a series (gasp) goto
statements instead of the "return"?  Like this:

	if (ia64_pal_mem_attrib(&attrib) != 0)
		goto skip_mem_attrib;

	... code to print things in &attrib

skip_mem_attrib:


This would require a bit more re-arranging of the code to
make all the uses of each PAL call fall right after the
call.

-Tony
