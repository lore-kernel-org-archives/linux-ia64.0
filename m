From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 22 Feb 2005 22:42:22 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <1109112142.6024.119.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	 <1109109833.6024.109.camel@laptopd505.fenrus.org>
	 <yq04qg4i5wu.fsf@jaguar.mkp.net>
In-Reply-To: <yq04qg4i5wu.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@wildopensource.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2005-02-22 at 17:30 -0500, Jes Sorensen wrote:
> 
> For userspace it's used by some of the MPI type apps in userland.

you got to be kidding. Why are these MPI apps accessing memory that the
kernel has mapped cached (eg ram) via /dev/mem?


(eg my proposal is to make /dev/mem to be just device memory not kernel
accessable ram; wouldn't that solve the entire issue cleanly ?)

