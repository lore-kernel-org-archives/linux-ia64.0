From: Keith Owens <kaos@sgi.com>
Date: Wed, 16 Jun 2004 20:22:45 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality
Message-Id: <7620.1087417365@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 16 Jun 2004 18:28:22 +0100, 
Christoph Hellwig <hch@infradead.org> wrote:
>> +static void
>> +xpc_kdb_print_users(xpc_registration_t *registration, int ch_number)
>> +{
>> +	kdb_printf("xpc_registrations[channel=%d] (0x%p):\n", ch_number,
>> +							(void *) registration);
>> +
>> +	kdb_printf("\t&sema=0x%p\n", (void *) &registration->sema);
>> +	kdb_printf("\tfunc=0x%p\n", (void *) registration->func);
>> +	kdb_printf("\tkey=0x%p\n", registration->key);
>> +	kdb_printf("\tnentries=%d\n", registration->nentries);
>> +	kdb_printf("\tmsg_size=%d\n", registration->msg_size);
>> +	kdb_printf("\tassigned_limit=%d\n", registration->assigned_limit);
>> +	kdb_printf("\tidle_limit=%d\n", registration->idle_limit);
>> +}
>
>IIRC Keith objected against adding kdb-related code to mainline in the past.

No, I objected to mainline kdb code like a serial console hook being
scattered across other patches.  This is not mainline kdb code, it is
using kdb to add a debugging feature to other code.  I have no
objection to that, code such as ACPI has done that in the past.

>And IMHO it's indeed better placed in the kdb patch.

Absolutely not.  kdb has no interest in the debugging entries of
individual subsystems, in the same way that printk() does not care who
calls it.

BTW, with kdb v4.4 you no longer need the extra CFLAGS, drop
CFLAGS_xp_main.o += -I $(TOPDIR)/arch/$(ARCH)/kdb

