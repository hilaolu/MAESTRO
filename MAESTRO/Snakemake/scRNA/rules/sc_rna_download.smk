
import os

# Resolve download command: handle missing key, None value, or empty string
_download_cmd = config.get("download_command", None)
if not _download_cmd:
    _download_cmd = "wget -O"


def _write_url_list(urls):
    """Encode a list of URLs into a newline-separated string, safe for bash iteration."""
    return '\n'.join(urls)


if config["platform"] == "10x-genomics":
    rule download_fastq:
        """Download all FASTQ files for a 10x-genomics sample."""
        output:
            r1 = temp("Result/Fastq/{sample}/{sample}_R1.fastq.gz"),
            r2 = temp("Result/Fastq/{sample}/{sample}_R2.fastq.gz"),
        params:
            r1_urls = lambda wildcards: _write_url_list(FILES[wildcards.sample]["R1"]),
            r2_urls = lambda wildcards: _write_url_list(FILES[wildcards.sample]["R2"]),
            download_cmd = _download_cmd,
        log:
            "Result/Log/{sample}_download.log"
        benchmark:
            "Result/Benchmark/{sample}/{sample}_Download.benchmark"
        shell:
            """
            # Download R1 files and concatenate
            first=true
            IFS=$'\\n'
            for url in {params.r1_urls}; do
                if [ "$first" = true ]; then
                    {params.download_cmd} {output.r1} "$url" >> {log} 2>&1
                    first=false
                else
                    {params.download_cmd} {output.r1}.part "$url" >> {log} 2>&1
                    cat {output.r1}.part >> {output.r1}
                    rm -f {output.r1}.part
                fi
            done

            # Download R2 files and concatenate
            first=true
            for url in {params.r2_urls}; do
                if [ "$first" = true ]; then
                    {params.download_cmd} {output.r2} "$url" >> {log} 2>&1
                    first=false
                else
                    {params.download_cmd} {output.r2}.part "$url" >> {log} 2>&1
                    cat {output.r2}.part >> {output.r2}
                    rm -f {output.r2}.part
                fi
            done
            unset IFS
            """

elif config["platform"] == "Dropseq":
    rule download_fastq:
        """Download all FASTQ files for a Dropseq sample."""
        output:
            r1 = temp("Result/Fastq/{sample}/{sample}_R1.fastq.gz"),
            r2 = temp("Result/Fastq/{sample}/{sample}_R2.fastq.gz"),
        params:
            r1_urls = lambda wildcards: _write_url_list(FILES[wildcards.sample]["R1"]),
            r2_urls = lambda wildcards: _write_url_list(FILES[wildcards.sample]["R2"]),
            download_cmd = _download_cmd,
        log:
            "Result/Log/{sample}_download.log"
        benchmark:
            "Result/Benchmark/{sample}/{sample}_Download.benchmark"
        shell:
            """
            # Download R1 files and concatenate
            first=true
            IFS=$'\\n'
            for url in {params.r1_urls}; do
                if [ "$first" = true ]; then
                    {params.download_cmd} {output.r1} "$url" >> {log} 2>&1
                    first=false
                else
                    {params.download_cmd} {output.r1}.part "$url" >> {log} 2>&1
                    cat {output.r1}.part >> {output.r1}
                    rm -f {output.r1}.part
                fi
            done

            # Download R2 files and concatenate
            first=true
            for url in {params.r2_urls}; do
                if [ "$first" = true ]; then
                    {params.download_cmd} {output.r2} "$url" >> {log} 2>&1
                    first=false
                else
                    {params.download_cmd} {output.r2}.part "$url" >> {log} 2>&1
                    cat {output.r2}.part >> {output.r2}
                    rm -f {output.r2}.part
                fi
            done
            unset IFS
            """
