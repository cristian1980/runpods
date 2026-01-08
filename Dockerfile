FROM runpod/worker-comfyui:5.5.1-base
# Copy your provision script into the container (if it's not already there)
COPY provisioning.sh /provisioning.sh

# Make sure it is executable
RUN chmod +x /provisioning.sh

# Override the CMD to run your new script
CMD ["/provisioning.sh"]
