From: Christoph Hellwig <hch@caldera.de>
Date: Wed, 14 Nov 2001 17:49:35 +0000
Subject: Re: [Linux-ia64] correct seg fault address on ia-64??
Message-Id: <marc-linux-ia64-105590698805511@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805506@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805506@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 14, 2001 at 09:22:31AM -0800, Rich Altmaier wrote:
> What is out there for gcc?

gcc -W -Werror..

Seriously, gcc supports 64bit targets for a _very_ long time now
(more than 5 years) - people should have gotten their code cleaned
up..

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

