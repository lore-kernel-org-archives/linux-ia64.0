From: Paul Jackson <pj@sgi.com>
Date: Thu, 20 Nov 2003 04:47:04 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106930373005828@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

pj wrote:
> There will be a single routine for each, in a new lib file.

Bill replied:
> The format_cpumask() bits did that in ...

Yup, as I knew, before and after that point in time.  Just not then.
The older I get, the more I appreciate how non-linear awareness is.

> I'm not convinced it does. 

You're right - the code seems ok on this point.

> I don't see any problems with changing the format at this stage ...

Ok - I will continue along this path ... at least until when and
if someone raises a good objection.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
