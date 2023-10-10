Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 059CFCD98CC
	for <linux-ia64@archiver.kernel.org>; Tue, 10 Oct 2023 22:23:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229735AbjJJWXO (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Tue, 10 Oct 2023 18:23:14 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40726 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229769AbjJJWXO (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Tue, 10 Oct 2023 18:23:14 -0400
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 51A148F;
        Tue, 10 Oct 2023 15:23:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
        MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=9AGiLTlqtyIGaBzD7IOjNpQgtkRKRaKi8pUmOot2w4M=; b=tyglCR9LBh6Vl3Fph2HnHlHQtO
        acIvmZrvWyjcuuE6PE8hvNLiuQT1GSN++6loqxNUa/o5kIe8nFkWTpBVvMOq2Ice63MgrMEtsq6S2
        6KlEKbIJ9q/QxWOredRN8uJL63aL0nDdwWK/DwqQ4Yz0veLS/2jlIoU4k7H98/Nt1f/4/8sO6yAL+
        PsMAkrf40vjdvyCGjv5QD/uKrfrNzKsyAV4i6aLBNtwtjTKECoSS3lPIT1seEL/UOPP9cY6UjRDTf
        QZuMsYmPqnGLgN7YaMNW8aWr4wbw9yGiqe2il6HHywqVm1fmptxPJ4p2jowp8+fWw+2XPiIfvRybX
        bdKpFW+A==;
Received: from mcgrof by bombadil.infradead.org with local (Exim 4.96 #2 (Red Hat Linux))
        id 1qqL7a-00EFUa-0R;
        Tue, 10 Oct 2023 22:22:34 +0000
Date:   Tue, 10 Oct 2023 15:22:34 -0700
From:   Luis Chamberlain <mcgrof@kernel.org>
To:     j.granados@samsung.com
Cc:     willy@infradead.org, josh@joshtriplett.org,
        Kees Cook <keescook@chromium.org>,
        Iurii Zaikin <yzaikin@google.com>,
        Heiko Carstens <hca@linux.ibm.com>,
        Vasily Gorbik <gor@linux.ibm.com>,
        Alexander Gordeev <agordeev@linux.ibm.com>,
        Christian Borntraeger <borntraeger@linux.ibm.com>,
        Sven Schnelle <svens@linux.ibm.com>,
        Gerald Schaefer <gerald.schaefer@linux.ibm.com>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org,
        "H. Peter Anvin" <hpa@zytor.com>,
        Andy Lutomirski <luto@kernel.org>,
        Paul Walmsley <paul.walmsley@sifive.com>,
        Palmer Dabbelt <palmer@dabbelt.com>,
        Albert Ou <aou@eecs.berkeley.edu>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Nicholas Piggin <npiggin@gmail.com>,
        Christophe Leroy <christophe.leroy@csgroup.eu>,
        Guo Ren <guoren@kernel.org>,
        Alexey Gladkov <legion@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-riscv@lists.infradead.org, linuxppc-dev@lists.ozlabs.org,
        linux-ia64@vger.kernel.org, linux-csky@vger.kernel.org,
        Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 0/7] sysctl: Remove sentinel elements from arch
Message-ID: <ZSXOqoCRH0PiBiIG@bombadil.infradead.org>
References: <20231002-jag-sysctl_remove_empty_elem_arch-v3-0-606da2840a7a@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20231002-jag-sysctl_remove_empty_elem_arch-v3-0-606da2840a7a@samsung.com>
Sender: Luis Chamberlain <mcgrof@infradead.org>
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

On Mon, Oct 02, 2023 at 01:30:35PM +0200, Joel Granados via B4 Relay wrote:
> V3:
> * Removed the ia64 patch to avoid conflicts with the ia64 removal
> * Rebased onto v6.6-rc4
> * Kept/added the trailing comma for the ctl_table arrays. This was a comment
>   that we received "drivers/*" patch set.
> * Link to v2: https://lore.kernel.org/r/20230913-jag-sysctl_remove_empty_elem_arch-v2-0-d1bd13a29bae@samsung.com

Thanks! I replaced the v2 with this v3 on sysctl-next.

  Luis
