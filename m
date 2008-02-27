From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 27 Feb 2008 12:18:12 +0000
Subject: Re: ia64_mca_cpe_int_handler
Message-Id: <47C55504.6070300@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BF02EC.4080102@bull.net>
In-Reply-To: <47BF02EC.4080102@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Is this records per cpu or records total?

Well, I planed 2 + 2 global log buffers for MCA / INIT. (As today.)
The 1st CPU can use 1st buffer (and increments the atomic variable).
For additional MCAs, it fills in the 2nd buffer.
The other CPUs fill in the 2nd buffer, too.
Yes, we overwrite the 2nd buffer. It goes like this:
- increment the atomic variable, wmb()
- memcpy() the log into the 2nd buffer, wmb()
- increment the atomic variable
- before starting, verify if the atomic variable is odd,
  use compare-and-swap for the incrementing it

memcpy() should finish in a relatively short time.
Should it provoke another MCA...
(The actual code also assumes that the MCA handler is "hard core".)

We could have dedicated buffers to each CPU, and more than 2 of them
per CPU.
Yet all the resources have to be pre-allocated.
For some hopefully very unlikely events...

Eventually, this algorithm is easily modifiable to handle "n" buffers
(overwriting the last one).

Thanks,

Zoltan 
