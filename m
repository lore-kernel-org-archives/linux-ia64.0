From: Anton Blanchard <anton@samba.org>
Date: Thu, 13 May 2004 18:43:18 +0000
Subject: Re: Who owns those locks ?
Message-Id: <20040513184318.GG11588@krispykreme>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A1F4BE.4A298352@nospam.org>
In-Reply-To: <40A1F4BE.4A298352@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


> Why don't you put the ID of the owner of the lock in the lock word ?
> Here is your patch for IA-64.
> Doesn't cost any additional instruction, you can have it in your
> "production" kernel, too.

We already do this on ppc64.

Anton
