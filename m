From: Jes Sorensen <jes@sgi.com>
Date: Mon, 19 May 2008 09:55:10 +0000
Subject: Re: ld2.acq - sign extension?
Message-Id: <48314E7E.1010604@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0wslqiqyp.fsf@jaguar.mkp.net>
In-Reply-To: <yq0wslqiqyp.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab wrote:
> Jes Sorensen <jes@sgi.com> writes:
> 
>> Basically if I apply the below diff my code no longer works. However I
>> am under the impression that ld2.acq does sign extension?
> 
> ld always zero extends.

Hi Andreas,

Thats what I thought too, but do you have any explanation as to why
that patch I included makes a difference?

Thanks,
Jes
