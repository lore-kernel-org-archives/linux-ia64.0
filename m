From: dann frazier <dannf@hp.com>
Date: Fri, 02 Jun 2006 06:32:01 +0000
Subject: Re: [PATCH 1/1] ia64: perfmon.c trips BUG_ON in put_page_testzero
Message-Id: <20060602063200.GL26594@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <43E1129C.mailxEOB11K2KM@eag09.americas.sgi.com>
In-Reply-To: <43E1129C.mailxEOB11K2KM@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 17, 2006 at 02:24:07PM -0700, Stephane Eranian wrote:
> Anil,
> 
> This patch does not seem to be needed anymore for 2.6.16. Neither
> Cliff nor I were able to reproduce with that versionm. Cliff mentioned
> that he wanted to try and get his patch into SLES9 which uses an
> older version of ther kernel.

Anyone know if this is a problem in 2.4?

-- 
dann frazier | HP Open Source and Linux Organization
