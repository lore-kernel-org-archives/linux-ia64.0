From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 19 Oct 2007 17:44:53 +0000
Subject: Re: [IA64] Reduce __clear_bit_unlock overhead
Message-Id: <Pine.LNX.4.64.0710191042580.30937@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710182037220.25820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 19 Oct 2007, Zoltan Menyhart wrote:

> Can you please tell me what is the advantage of ".nta " on the store?
> I far as I can see in the I2 Microarch. Guide, Table 3-2 Processor
> Cache Hints, ".nta " on stores means:
> - L2 NRU bit is not updated
> - No slot is allocated in L3

The advantage is that the cacheline is pushed out faster to real memory 
which may save cacheline eviction if the lock has to be acquired by 
another processor.

> In order to be able to take advantage of an "st.nta", you have to
> use "ld.nta" in __clear_bit_unlock(), and at the bit lock
> acquisition, too.

Hmmm.. Yes this would make the function more complex to read. Maybe its 
not worth having the nta there.
