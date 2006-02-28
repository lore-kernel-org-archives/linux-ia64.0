From: Jes Sorensen <jes@sgi.com>
Date: Tue, 28 Feb 2006 15:45:10 +0000
Subject: Re: git question
Message-Id: <44047006.9030204@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq08xsez26a.fsf@jaguar.mkp.net>
In-Reply-To: <yq08xsez26a.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>Another git issue:
>>
>>[jes@tomahawk linux-2.6]$ git-pull
>>fatal: read error (Connection reset by peer)
>>Fetch failure: git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
>>
>>Anyone seen that one before? Worked last week.
> 
> 
> Not my fault (this time).  I haven't pushed anything up to kernel.org
> (or made any other repo changes) since Feb 18th.  The version of git
> on kernel.org was updated to 1.2.3 on Feb 23rd. What date was your last
> good pull?

Hmm I wonder if thats it. I had a good pull on Thursday for sure, but
I think I did on Friday as well. Someone else reported problems against
other repos.

It seems that if one keeps retrying, eventually it will work, but it
seems very random.

Cheers,
Jes
