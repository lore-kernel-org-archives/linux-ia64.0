From: Paul Jackson <pj@sgi.com>
Date: Fri, 23 Sep 2005 17:38:18 +0000
Subject: Re: Using Cpusets with HyperThreads
Message-Id: <20050923103818.486d4cfe.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050923000016.2cc416ac.pj@sgi.com>
In-Reply-To: <20050923000016.2cc416ac.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony wrote:
>  cpus S(0-15).t=0

Yeah - something like that.  Well said.  The "/slice" is useful enough
now on uniform architectures, but someway to do what you describe will
be well worth doing too, once I think on it some more.

Thanks.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
