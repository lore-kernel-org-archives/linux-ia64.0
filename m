From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 27 Feb 2004 09:17:40 +0000
Subject: Re: General question about building kernel.org distros
Message-Id: <3048.1077873460@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <403D151C.1F7A96D1@email.mot.com>
In-Reply-To: <403D151C.1F7A96D1@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 25 Feb 2004 15:35:24 -0600, 
Mario Smarduch <cms063@email.mot.com> wrote:
>I just have a general question regarding building IA64 2.4.25
>stock kernel from kernel.org. After downloading, and building
>with the default  config there were tons of compile errors.

You need an arch specific patch to go over the base 2.4.25 kernel.
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.25-ia64-040218.diff.gz

