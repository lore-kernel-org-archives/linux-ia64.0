From: Thomas Renninger <trenn@suse.de>
Date: Fri, 10 Feb 2006 02:07:43 +0000
Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <43EBF56F.7090507@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E044F0914@orsmsx403.amr.corp.intel.com>
In-Reply-To: <971FCB6690CD0E4898387DBF7552B90E044F0914@orsmsx403.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

Moore, Robert wrote:
> The next thing that would be useful is to know what method(s) are
> executing when the message pops out.
> 
> 
>> -----Original Message-----
>> From: Luck, Tony
>> Sent: Thursday, February 09, 2006 1:16 PM
>> To: Moore, Robert; 'linux-acpi@vger.kernel.org'
>> Cc: 'linux-ia64@vger.kernel.org'
>> Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
>>
>> But I goofed and muddled up my two problems.  I tried
>> booting on my zx1 ... which was broken altogether by
>> recent acpi changes.
>>
>> Getting back to the rx2620 ... deleting those lines makes
>> no difference.  I still boot ok, I still see the unaligned
>> access messages.
>>
>> /proc/acpi/dsdt for that system attached.
>>
>> -Tony

I also got kernel missalignment errors..., unfortunately also
a lot of slab debugger errors until the machine rebooted, so
I didn't care too much about the missalignments, but these
could have the same cause?

I now could nail the mem
corruptions down to ACPICA-20051021 by binary search.
It's late, maybe I got something wrong, but I am quite sure the
culprit lies there.

The patch is huge, but maybe it's just one of the other pragmas or
whatever related?:

grep pragma ../ACPICA_20051021.patch
+#pragma pack(1)
+#pragma pack()
+#pragma pack(1)
+#pragma pack()


     Thomas
