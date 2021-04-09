From: Kees Cook <keescook@chromium.org>
Date: Fri, 09 Apr 2021 03:10:24 +0000
Subject: Re: [PATCH 11/20] kbuild: ia64: use common install script
Message-Id: <202104082010.6976DE0B@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210407053419.449796-1-gregkh@linuxfoundation.org>
 <20210407053419.449796-12-gregkh@linuxfoundation.org>
In-Reply-To: <20210407053419.449796-12-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>, linux-kbuild@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Apr 07, 2021 at 07:34:10AM +0200, Greg Kroah-Hartman wrote:
> The common scripts/install.sh script will now work for ia64, all that
> is needed is to add the compressed image type to it.  So add that file
> type check and the ability to call /usr/sbin/elilo after copying the
> kernel.  With that we can remove the ia64-only version of the file.
> 
> Cc: linux-ia64@vger.kernel.org
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
