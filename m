From: Jay Lan <jlan@sgi.com>
Date: Thu, 17 Aug 2006 00:34:56 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <44E3B9B0.5050103@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jay Lan wrote:
> Zou Nan hai wrote:
> 
>> On Wed, 2006-08-16 at 03:15, Jay Lan wrote:
>>
>>> Zou Nan hai wrote:
>>>
>>
>>   Did you pass the correct kernel parameter to --append?
>>   It seems that root filesystem was not able to be mounted.
>>
> 
> I finally was able to boot up the crash dump kernel.
> Unfortunately the 'cp vmcore /var/tmp' crashed due to
> out of memory. :(

Incresing boot parameter from 128M@256M to 256M@256M
fixed the problem. :)

Thanks you, Nanhai!

- jay

> 
> 
