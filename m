From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 10 Nov 2003 19:10:42 +0000
Subject: Re: discontig patch question
Message-Id: <marc-linux-ia64-106849183102842@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106847971018555@msgid-missing>
In-Reply-To: <marc-linux-ia64-106847971018555@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 10, 2003 at 11:08:31AM -0800, Jesse Barnes wrote:
> Well, strictly speaking I don't think start _has_ to align on those
> conditions, but the hugetlb stuff may that it does (I haven't looked).

s/may/may assume/
