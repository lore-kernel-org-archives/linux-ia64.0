From: Dennis Dalessandro <dennis.dalessandro@cornelisnetworks.com>
Date: Thu, 31 Mar 2022 17:41:50 +0000
Subject: Re: [PATCH 11/22] rdmavt: Replace comments with C99 initializers
Message-Id: <865be9e8-3702-af45-95e8-1371dd6c43b2@cornelisnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <20220326165909.506926-11-benni@stuerz.xyz> <YkAMlurdV15gNROq@unreal>
In-Reply-To: <YkAMlurdV15gNROq@unreal>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Leon Romanovsky <leon@kernel.org>, =?UTF-8?Q?Benjamin_St=c3=bcrz?= <benni@stuerz.xyz>
Cc: andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On 3/27/22 3:04 AM, Leon Romanovsky wrote:
> On Sat, Mar 26, 2022 at 05:58:58PM +0100, Benjamin Stürz wrote:
>> This replaces comments with C99's designated
>> initializers because the kernel supports them now.
>>
>> Signed-off-by: Benjamin Stürz <benni@stuerz.xyz>
>> ---
>>  drivers/infiniband/sw/rdmavt/rc.c | 62 +++++++++++++++----------------
>>  1 file changed, 31 insertions(+), 31 deletions(-)
>>
>> diff --git a/drivers/infiniband/sw/rdmavt/rc.c b/drivers/infiniband/sw/rdmavt/rc.c
>> index 4e5d4a27633c..121b8a23ac07 100644
>> --- a/drivers/infiniband/sw/rdmavt/rc.c
>> +++ b/drivers/infiniband/sw/rdmavt/rc.c
>> @@ -10,37 +10,37 @@
>>   * Convert the AETH credit code into the number of credits.
>>   */
>>  static const u16 credit_table[31] = {
>> -	0,                      /* 0 */
>> -	1,                      /* 1 */
>> -	2,                      /* 2 */
>> -	3,                      /* 3 */
>> -	4,                      /* 4 */
>> -	6,                      /* 5 */
>> -	8,                      /* 6 */
>> -	12,                     /* 7 */
>> -	16,                     /* 8 */
>> -	24,                     /* 9 */
>> -	32,                     /* A */
>> -	48,                     /* B */
>> -	64,                     /* C */
>> -	96,                     /* D */
>> -	128,                    /* E */
>> -	192,                    /* F */
>> -	256,                    /* 10 */
>> -	384,                    /* 11 */
>> -	512,                    /* 12 */
>> -	768,                    /* 13 */
>> -	1024,                   /* 14 */
>> -	1536,                   /* 15 */
>> -	2048,                   /* 16 */
>> -	3072,                   /* 17 */
>> -	4096,                   /* 18 */
>> -	6144,                   /* 19 */
>> -	8192,                   /* 1A */
>> -	12288,                  /* 1B */
>> -	16384,                  /* 1C */
>> -	24576,                  /* 1D */
>> -	32768                   /* 1E */
>> +	[0x00] = 0,
>> +	[0x01] = 1,
>> +	[0x02] = 2,
>> +	[0x03] = 3,
>> +	[0x04] = 4,
>> +	[0x05] = 6,
>> +	[0x06] = 8,
>> +	[0x07] = 12,
>> +	[0x08] = 16,
>> +	[0x09] = 24,
>> +	[0x0A] = 32,
>> +	[0x0B] = 48,
>> +	[0x0C] = 64,
>> +	[0x0D] = 96,
>> +	[0x0E] = 128,
>> +	[0x0F] = 192,
>> +	[0x10] = 256,
>> +	[0x11] = 384,
>> +	[0x12] = 512,
>> +	[0x13] = 768,
>> +	[0x14] = 1024,
>> +	[0x15] = 1536,
>> +	[0x16] = 2048,
>> +	[0x17] = 3072,
>> +	[0x18] = 4096,
>> +	[0x19] = 6144,
>> +	[0x1A] = 8192,
>> +	[0x1B] = 12288,
>> +	[0x1C] = 16384,
>> +	[0x1D] = 24576,
>> +	[0x1E] = 32768
>>  };
> 
> I have hard time to see any value in this commit, why is this change needed?
> 

I tend to agree. This doesn't really improve things. It's a NAK from me.

-Denny
