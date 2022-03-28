From: Kalle Valo <kvalo@kernel.org>
Date: Mon, 28 Mar 2022 09:28:30 +0000
Subject: Re: [PATCH 21/22] rtw89: Replace comments with C99 initializers
Message-Id: <87k0cezarl.fsf@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
        <20220326165909.506926-21-benni@stuerz.xyz>
        <f7bb9164-2f66-8985-5771-5f31ee5740b7@lwfinger.net>
In-Reply-To: <f7bb9164-2f66-8985-5771-5f31ee5740b7@lwfinger.net> (Larry
        Finger's message of "Sat, 26 Mar 2022 13:55:33 -0500")
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Benjamin =?utf-8?Q?St=C3=BCrz?= <benni@stuerz.xyz>, andrew@lunn.ch, sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

Larry Finger <Larry.Finger@lwfinger.net> writes:

> On 3/26/22 11:59, Benjamin Stürz wrote:
>> This replaces comments with C99's designated
>> initializers because the kernel supports them now.
>>
>> Signed-off-by: Benjamin Stürz <benni@stuerz.xyz>
>> ---
>>   drivers/net/wireless/realtek/rtw89/coex.c | 40 +++++++++++------------
>>   1 file changed, 20 insertions(+), 20 deletions(-)
>>
>> diff --git a/drivers/net/wireless/realtek/rtw89/coex.c b/drivers/net/wireless/realtek/rtw89/coex.c
>> index 684583955511..3c83a0bfb120 100644
>> --- a/drivers/net/wireless/realtek/rtw89/coex.c
>> +++ b/drivers/net/wireless/realtek/rtw89/coex.c
>> @@ -97,26 +97,26 @@ static const struct rtw89_btc_fbtc_slot s_def[] = {
>>   };
>>     static const u32 cxtbl[] = {
>> -	0xffffffff, /* 0 */
>> -	0xaaaaaaaa, /* 1 */
>> -	0x55555555, /* 2 */
>> -	0x66555555, /* 3 */
>> -	0x66556655, /* 4 */
>> -	0x5a5a5a5a, /* 5 */
>> -	0x5a5a5aaa, /* 6 */
>> -	0xaa5a5a5a, /* 7 */
>> -	0x6a5a5a5a, /* 8 */
>> -	0x6a5a5aaa, /* 9 */
>> -	0x6a5a6a5a, /* 10 */
>> -	0x6a5a6aaa, /* 11 */
>> -	0x6afa5afa, /* 12 */
>> -	0xaaaa5aaa, /* 13 */
>> -	0xaaffffaa, /* 14 */
>> -	0xaa5555aa, /* 15 */
>> -	0xfafafafa, /* 16 */
>> -	0xffffddff, /* 17 */
>> -	0xdaffdaff, /* 18 */
>> -	0xfafadafa  /* 19 */
>> +	[0]  = 0xffffffff,
>> +	[1]  = 0xaaaaaaaa,
>> +	[2]  = 0x55555555,
>> +	[3]  = 0x66555555,
>> +	[4]  = 0x66556655,
>> +	[5]  = 0x5a5a5a5a,
>> +	[6]  = 0x5a5a5aaa,
>> +	[7]  = 0xaa5a5a5a,
>> +	[8]  = 0x6a5a5a5a,
>> +	[9]  = 0x6a5a5aaa,
>> +	[10] = 0x6a5a6a5a,
>> +	[11] = 0x6a5a6aaa,
>> +	[12] = 0x6afa5afa,
>> +	[13] = 0xaaaa5aaa,
>> +	[14] = 0xaaffffaa,
>> +	[15] = 0xaa5555aa,
>> +	[16] = 0xfafafafa,
>> +	[17] = 0xffffddff,
>> +	[18] = 0xdaffdaff,
>> +	[19] = 0xfafadafa
>>   };
>>     struct rtw89_btc_btf_tlv {
>
>
> Is this change really necessary? Yes, the entries must be ordered;
> however, the comment carries that information at very few extra
> characters. To me, this patch looks like unneeded source churn.

One small benefit I see is to avoid the comment index being wrong and
there would be no way to catch that. But otherwise I don't have any
opinion about this.

-- 
https://patchwork.kernel.org/project/linux-wireless/list/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
