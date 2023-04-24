From: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Date: Mon, 24 Apr 2023 17:27:42 +0000
Subject: Re: [PATCH] scripts: Remove ICC-related dead code
Message-Id: <CANiq72=Kb6ckhU8Ss9=Dg4Zn11Us+DLbKnNWAVaTb-nv7Y=ARA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221016182349.49308-1-masahiroy@kernel.org> <20230424162110.11082-1-lrh2000@pku.edu.cn>
In-Reply-To: <20230424162110.11082-1-lrh2000@pku.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Ruihan Li <lrh2000@pku.edu.cn>
Cc: torvalds@linux-foundation.org, masahiroy@kernel.org, arnd@arndb.de, bp@alien8.de, dave.hansen@linux.intel.com, devel@acpica.org, lenb@kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, llvm@lists.linux.dev, mingo@redhat.com, nathan@kernel.org, ndesaulniers@google.com, ojeda@kernel.org, rafael@kernel.org, robert.moore@intel.com, terrelln@fb.com, tglx@linutronix.de, trix@redhat.com, x86@kernel.org

On Mon, Apr 24, 2023 at 6:22=E2=80=AFPM Ruihan Li <lrh2000@pku.edu.cn> wrot=
e:
>
> Intel compiler support has already been completely removed in commit
> 95207db8166a ("Remove Intel compiler support"). However, it appears that
> there is still some ICC-related code in scripts/cc-version.sh. There is
> no harm in leaving the code as it is, but removing the dead code makes
> the codebase a bit cleaner.

Reviewed-by: Miguel Ojeda <ojeda@kernel.org>

Cheers,
Miguel
