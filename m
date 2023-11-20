Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cloudflare.com header.i=@cloudflare.com header.b="TJV+6/Hj"
Received: from mail-pj1-x1031.google.com (mail-pj1-x1031.google.com [IPv6:2607:f8b0:4864:20::1031])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1258CD2
	for <linux-ia64@vger.kernel.org>; Mon, 20 Nov 2023 14:53:04 -0800 (PST)
Received: by mail-pj1-x1031.google.com with SMTP id 98e67ed59e1d1-280165bba25so3348543a91.2
        for <linux-ia64@vger.kernel.org>; Mon, 20 Nov 2023 14:53:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cloudflare.com; s=google09082023; t=1700520783; x=1701125583; darn=vger.kernel.org;
        h=cc:to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=jj/vQll/FXoy8ynJ7Qc2odNrUXWiiF64P1hSHAKTnLo=;
        b=TJV+6/Hjq4Mewn2fI8FIeDdxzYZ3UyjLy2g1qYqHn0qKm4X5Lai6NZRNtH5YJ98k1I
         a6l7RGAy8lpggsIo5s8nb6WLFemAN7F8KRsKr0LKn4uZgW8J9rqWNUY4bMSvUIio7204
         lQiUwoB54lkZvokSYE0NUY9Ui6mbjBtTp6dw5oDhSzvq+ASDN90KV2jxoowcLbHEewGL
         D9E8G5H2+dWqZ967YfP02MaS+tqJznZLG2DUYr4BgvUHMq/W0Y5cayHWxgNFPAOQgF/s
         oSq86P6Z52FcwSMa6/DUyc0mXeAjxFxDTtvYOuNm+tvst2a0Ds4ecgV0bWB6qd36dxr6
         99IQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1700520783; x=1701125583;
        h=cc:to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=jj/vQll/FXoy8ynJ7Qc2odNrUXWiiF64P1hSHAKTnLo=;
        b=coWyKwvtlGrIsjUyQjBpeFGtyyKH+uK2j5tsgchKhWIVlGBkZZbfBaQU5OkQ7RhXKp
         xQ6SMM8DMBaA3mLmhjIpSPpXgo42xSjSv+XUCLBFElGlyScYaNeaQXbsiseO4Hq62VDk
         OGHjPL6+mNeQepVoCaj7LVlSXO9/LOgOmxrB7tyiHyXzxiAWFmSLoweYUZS6DvUtVm/S
         7EEqyneOKQ3axTfij919/YBt1Sd09eOFmX3BWx5YRhJ1vxG8GdkrBdLRmhC25FU68z5J
         UsZI9vP9uRv3sw0nKE57jGiahupC3WGCVYc8+VvjWlLBWsR5LIaNDnXJ7whIrFJHT6Q6
         qJIQ==
X-Gm-Message-State: AOJu0YxuroMjzjt7Q07q4G1pWN1oWxcMMnnAdpZxA92T91iUvFB3sn/+
	whwIZ42/viIM53vGxKFUd1TaFLPOJW6anXbjNdpUjw==
X-Google-Smtp-Source: AGHT+IFZPPhV0R/g5zHGb3q3Uo9IH7rXXP80OMq0eithxekw9SzGz9ATfztUful4gMY68aa6sJe0kX0Yn689XQCOKAw=
X-Received: by 2002:a17:90b:1a89:b0:27d:2364:44f6 with SMTP id
 ng9-20020a17090b1a8900b0027d236444f6mr7022804pjb.6.1700520783377; Mon, 20 Nov
 2023 14:53:03 -0800 (PST)
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Ignat Korchagin <ignat@cloudflare.com>
Date: Mon, 20 Nov 2023 22:52:52 +0000
Message-ID: <CALrw=nHpRQQaQTP_jZfREgrQEMpS8jBF8JQCv4ygqXycE-StaA@mail.gmail.com>
Subject: Potential config regression after 89cde455 ("kexec: consolidate kexec
 and crash options into kernel/Kconfig.kexec")
To: eric.devolder@oracle.com
Cc: linux@armlinux.org.uk, catalin.marinas@arm.com, will@kernel.org, 
	chenhuacai@kernel.org, geert@linux-m68k.org, tsbogend@alpha.franken.de, 
	James Bottomley <James.Bottomley@hansenpartnership.com>, deller@gmx.de, 
	ysato@users.sourceforge.jp, dalias@libc.org, glaubitz@physik.fu-berlin.de, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	dave.hansen@linux.intel.com, x86@kernel.org, 
	linux-kernel <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, 
	linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, 
	linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, 
	linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, 
	linux-sh@vger.kernel.org, kernel@xen0n.name, mpe@ellerman.id.au, 
	npiggin@gmail.com, christophe.leroy@csgroup.eu, paul.walmsley@sifive.com, 
	palmer@dabbelt.com, aou@eecs.berkeley.edu, hca@linux.ibm.com, 
	gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, 
	svens@linux.ibm.com, hpa@zytor.com, keescook@chromium.org, paulmck@kernel.org, 
	Peter Zijlstra <peterz@infradead.org>, frederic@kernel.org, 
	Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, samitolvanen@google.com, 
	juerg.haefliger@canonical.com, arnd@arndb.de, rmk+kernel@armlinux.org.uk, 
	linus.walleij@linaro.org, sebastian.reichel@collabora.com, rppt@kernel.org, 
	kirill.shutemov@linux.intel.com, anshuman.khandual@arm.com, ziy@nvidia.com, 
	masahiroy@kernel.org, ndesaulniers@google.com, mhiramat@kernel.org, 
	ojeda@kernel.org, thunder.leizhen@huawei.com, xin3.li@intel.com, 
	tj@kernel.org, Greg KH <gregkh@linuxfoundation.org>, tsi@tuyoix.net, bhe@redhat.com, 
	hbathini@linux.ibm.com, sourabhjain@linux.ibm.com, boris.ostrovsky@oracle.com, 
	konrad.wilk@oracle.com, kernel-team <kernel-team@cloudflare.com>
Content-Type: text/plain; charset="UTF-8"

Good day!

We have recently started to evaluate Linux 6.6 and noticed that we
cannot disable CONFIG_KEXEC anymore, but keep CONFIG_CRASH_DUMP
enabled. It seems to be related to commit 89cde455 ("kexec:
consolidate kexec and crash options into kernel/Kconfig.kexec"), where
a CONFIG_KEXEC dependency was added to CONFIG_CRASH_DUMP.

In our current kernel (Linux 6.1) we only enable CONFIG_KEXEC_FILE
with enforced signature check to support the kernel crash dumping
functionality and would like to keep CONFIG_KEXEC disabled for
security reasons [1].

I was reading the long commit message, but the reason for adding
CONFIG_KEXEC as a dependency for CONFIG_CRASH_DUMP evaded me. And I
believe from the implementation perspective CONFIG_KEXEC_FILE should
suffice here (as we successfully used it for crashdumps on Linux 6.1).

Is there a reason for adding this dependency or is it just an
oversight? Would some solution of requiring either CONFIG_KEXEC or
CONFIG_KEXEC_FILE work here?

Ignat

[1]: https://mjg59.dreamwidth.org/28746.html
