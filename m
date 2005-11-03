From: Keith Owens <kaos@sgi.com>
Date: Thu, 03 Nov 2005 07:34:48 +0000
Subject: Re: [patch] align signal-frame even when not using alternate signal-stack
Message-Id: <12071.1131003288@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051103064019.5B552B3421@localhost.localdomain>
In-Reply-To: <20051103064019.5B552B3421@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2 Nov 2005 22:40:19 -0800 (PST), 
davidm@mail.mostang.com (David Mosberger-Tang) wrote:
>At the moment, attempting to invoke a signal-handler on the normal
>stack is guaranteed to fail if the stack-pointer happens not to be
>16-byte aligned.

Itanium Software Conventions and Runtime Architecture Guide, section
7.1 says that the stack pointer must always be aligned on a 16 byte
boundary.  What software is not using 16 byte alignment for the stack?

