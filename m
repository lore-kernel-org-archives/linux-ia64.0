From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 27 May 2009 03:11:00 +0000
Subject: Re: [Patch 4/4] module: trim exception table in module_free()
Message-Id: <4A1CAF44.7000002@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090526083717.5050.32719.sendpatchset@localhost.localdomain> <20090526083751.5050.60959.sendpatchset@localhost.localdomain> <200905271151.28045.rusty@rustcorp.com.au>
In-Reply-To: <200905271151.28045.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, jdike@addtoit.com, mingo@elte.hu, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org

Rusty Russell wrote:
> On Tue, 26 May 2009 06:05:39 pm Amerigo Wang wrote:
>   
>>  void module_free(struct module *mod, void *module_region)
>>  {
>>  	vfree(module_region);
>> -	/* FIXME: If module_region = mod->init_region, trim exception
>> -	   table entries. */
>> +	if (module_region = mod->module_init)
>> +		mod->num_exentries = 0;
>>  }
>>     
>
> Hi Amerigo,
>
>    This looks wrong.  The extable covers both init and core exception entries.   
> We want to remove the ones in the module_init section.  The good news is that 
> it's sorted, so they're either at the start or the end (except sparc 32).
>   

Hi, Rusty.

Yes? The extable of a module is in '__ex_table' section, and during the 
section transfer, one
section will be either in module_init or module_core, so its entries are 
only in one of them,
not both, right?

Thank you.




