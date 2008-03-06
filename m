From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 06 Mar 2008 17:29:21 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <47D029F1.9070205@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>A rough estimation can be done as follows:
>>
>>Assume you have an MTBF of 30,000 hours.
>>The probability of having an MCA in a one minute time frame is less
>>than 1 / (60 * 30,000) < 10^(-6).
>>The probability of having two independent errors causing MCAs in
>>the same one minute time frame is less than 10^(-12).
> 
> 
> Russ's large systems change these.  Is 30,000 hours a plausible
> MTBF for a DIMM.  What if the system contains 8TB memory in 2GB
> DIMMs.  Now you have 4096 DIMM sticks in the system.  Redo your
> calculations for this large system.
> 
> -Tony

Can you please provide some real MTBF data?

Thanks,

Zoltan
