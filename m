From: Paul Jackson <pj@sgi.com>
Date: Thu, 20 Nov 2003 02:38:28 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106929606629830@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> There will be a single routine for each, in a new lib file.

My apologies to Bill Irwin.  As I was well aware earlier today,
and had already spaced out, this removal of duplicate code is
already a feature of his latest -mm format_cpumask() patch.

I should not have spoken as if I was breaking new ground there.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
