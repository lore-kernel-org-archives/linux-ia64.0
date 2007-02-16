From: "Ken Chen" <kenchen@google.com>
Date: Fri, 16 Feb 2007 23:16:49 +0000
Subject: Re: [PATCH] Remove stack hard limit on ia64
Message-Id: <b040c32a0702161516md3d48a5kf3b75e5027c82b16@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070216220654.GA11135@aepfle.de>
In-Reply-To: <20070216220654.GA11135@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Olaf Hering <olaf@aepfle.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On 2/16/07, Olaf Hering <olaf@aepfle.de> wrote:
> From: schwab@suse.de
>
> Un-Breaks pthreads, since Oct 2003.

why aren't you using /etc/security/limits.conf?
I think the stack limit can be set as big as 8TB on ia64 with default
16KB page size.

- Ken
