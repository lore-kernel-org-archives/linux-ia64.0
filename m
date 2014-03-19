From: Matt Turner <mattst88@gmail.com>
Date: Wed, 19 Mar 2014 22:19:51 +0000
Subject: Re: [PATCH 3/4] ARCH: AUDIT: implement syscall_get_arch for all arches
Message-Id: <CAEdQ38Ex47GxhN1ZZMu+RETpWs-ENbfCr8v=6iFg9p_QWaa9zw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395266643-3139-1-git-send-email-eparis@redhat.com> <1395266643-3139-3-git-send-email-eparis@redhat.com>
In-Reply-To: <1395266643-3139-3-git-send-email-eparis@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Paris <eparis@redhat.com>
Cc: linux-audit@redhat.com, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, linux@openrisc.net, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Wed, Mar 19, 2014 at 3:04 PM, Eric Paris <eparis@redhat.com> wrote:
> For all arches which support audit implement syscall_get_arch()

support audit -- is that AUDIT_ARCH? If so, alpha gained support
recently, so I think this patch needs to handle alpha too?
