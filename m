From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 03 Mar 2005 20:53:18 +0000
Subject: Re: [PATCH] Errenous use of memset and memcpy
Message-Id: <4227793E.3020403@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020106000504070006040800"
List-Id: <linux-ia64.vger.kernel.org>
References: <1108848352.682.2.camel@boxen>
In-Reply-To: <1108848352.682.2.camel@boxen>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020106000504070006040800
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 2/22/2005 9:37 AM, Bjorn Helgaas wrote:
> On Sun, 2005-02-20 at 11:38 +0100, Alexander Nyberg wrote:
>> ===== arch/ia64/ia32/ia32_signal.c 1.35 vs edited =====
>> --- 1.35/arch/ia64/ia32/ia32_signal.c	2005-01-25 21:23:45 +01:00
>> +++ edited/arch/ia64/ia32/ia32_signal.c	2005-02-20 11:32:55 +01:00
>> @@ -460,9 +460,9 @@ __ia32_rt_sigsuspend (compat_sigset_t *s
>>  	sigset_t oldset, set;
>>  
>>  	scr->scratch_unat = 0;	/* avoid leaking kernel bits to user level */
>> -	memset(&set, 0, sizeof(&set));
>> +	memset(&set, 0, sizeof(sigset_t));
> 
> To check that the above is correct, you have to go look up
> the declaration of "set".  Why not do this:
> 
> +	memset(&set, 0, sizeof(set));
> 
> which is clearly correct, regardless of the declaration?
>

Agree and I think memcpy is just fine. Tony, please apply the attached patch.

	-Arun


--------------020106000504070006040800
Content-Type: text/plain;
 name="sigsuspend-memcpy.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="sigsuspend-memcpy.patch"

LSBGaXggdGhlIGluY29ycmVjdCBhcmd1bWVudCB0byBzaXplb2YoKQotIG1lbWNweSBzaG91
bGQgYWx3YXlzIHN1Y2NlZWQgYmVjYXVzZSBpdCdzIGEga2VybmVsIHNwYWNlIHRvIGtlcm5l
bCBzcGFjZSBjb3B5LgoKU2lnbmVkLW9mZi1ieTogQXJ1biBTaGFybWEgPGFydW4uc2hhcm1h
QGludGVsLmNvbT4KCi0tLSBsaW51eC0yLjYtY3ZzL2FyY2gvaWE2NC9pYTMyL2lhMzJfc2ln
bmFsLmMJMyBGZWIgMjAwNSAxODoyOTo0NSAtMDAwMAkxLjI1CisrKyBsaW51eC0yLjYtY3Zz
L2FyY2gvaWE2NC9pYTMyL2lhMzJfc2lnbmFsLmMJMiBNYXIgMjAwNSAyMzo0MzowOSAtMDAw
MApAQCAtNDYwLDEwICs0NjAsOSBAQAogCXNpZ3NldF90IG9sZHNldCwgc2V0OwogCiAJc2Ny
LT5zY3JhdGNoX3VuYXQgPSAwOwkvKiBhdm9pZCBsZWFraW5nIGtlcm5lbCBiaXRzIHRvIHVz
ZXIgbGV2ZWwgKi8KLQltZW1zZXQoJnNldCwgMCwgc2l6ZW9mKCZzZXQpKTsKKwltZW1zZXQo
JnNldCwgMCwgc2l6ZW9mKHNldCkpOwogCi0JaWYgKG1lbWNweSgmc2V0LnNpZywgJnNzZXQt
PnNpZywgc2lnc2V0c2l6ZSkpCi0JCXJldHVybiAtRUZBVUxUOworCW1lbWNweSgmc2V0LnNp
ZywgJnNzZXQtPnNpZywgc2lnc2V0c2l6ZSk7CiAKIAlzaWdkZWxzZXRtYXNrKCZzZXQsIH5f
QkxPQ0tBQkxFKTsKIAo=
--------------020106000504070006040800--
