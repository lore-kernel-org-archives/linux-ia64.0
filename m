From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 08 Oct 2001 23:55:30 +0000
Subject: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805305@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sure, ok.  Would you like me to submit a new patch that includes the rate
limiting stuff as the default or do you just wanna hack that stuff back
in?

Thanks,
Jesse

On Mon, 8 Oct 2001, David Mosberger wrote:
> 
> I feel pretty strongly that we should handle fpswa faults the same way
> as unaligned faults.  Given that we rate limit the unaligned faults,
> I'd prefer to rate limit fpswa as well.  Of course, if you think you'd
> want to debug more than 5 faults at a time, you could change the
> tuning parameters (allowing for longer bursts, while keeping the
> logging rate the same).
> 
> 	--david
> 


