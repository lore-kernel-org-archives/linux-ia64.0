From: "Martin K. Petersen" <mkp@wildopensource.com>
Date: Tue, 19 Oct 2004 15:59:12 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <yq1ekjupulr.fsf@wilson.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> I have made setup_gate() an initcall.

Tony> Did you build with CONFIG_IA32_SUPPORT=y 

Yes I did.


Tony> ... the ia32_mem_init() call sets up some gate pages too, won't
Tony> it run into the same issue that setup_gate() does when called
Tony> before you've set up the pgtable_cache()? [Just guessing, I
Tony> didn't try this either]

No because it doesn't use the pgd/pmd/pte calls like setup_gate()
does.


Tony> I'm going to hold off on your patch while I see what happens to
Tony> the 4-level patch.

Okie.

-- 
Martin K. Petersen	Wild Open Source, Inc.
mkp@wildopensource.com	http://www.wildopensource.com/
