From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 Jan 2004 01:56:31 +0000
Subject: Re: script to check for guaranteed-to-crash-your-app warnings
Message-Id: <16379.26447.279073.661994@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16379.11171.475075.708058@napali.hpl.hp.com>
In-Reply-To: <16379.11171.475075.708058@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Argh, the situation must be worse than what I reported, since
"evolution" didn't show up at all!  evolution was missed because lynx
by default wraps lines after 80 columns.  I fixed the fetch-log script
and am rerunning it now.  I'm sure this would be a lot easier to do
for someone who has direct access to the log files...

	--david
