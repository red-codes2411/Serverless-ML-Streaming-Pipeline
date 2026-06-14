import streamlit as st
import boto3
import json
import uuid
from datetime import datetime

# Initialize the AWS Kinesis client for the Mumbai region
kinesis_client = boto3.client('kinesis', region_name='ap-south-1') 
STREAM_NAME = 'ml-feature-stream-dhanu' # Updated stream name with suffix

st.set_page_config(page_title="ML Feature Generator - Dhanu", layout="centered")

st.title("⚡ Real-Time ML Feature Generator (Dhanu)")
st.write("Simulate transaction data and stream it directly to AWS Kinesis in ap-south-1.")

# UI Controls for generating mock data
with st.form("event_generator_form"):
    st.subheader("Transaction Details")
    user_id = st.text_input("User ID", value="user_dhanu_101")
    tx_amount = st.slider("Transaction Amount ($)", min_value=1.0, max_value=5000.0, value=150.0)
    location_risk = st.selectbox("Location Risk Level", ["Low", "Medium", "High"])
    
    submitted = st.form_submit_button("Stream Event to Kinesis")

if submitted:
    # Construct the event payload
    event_payload = {
        "event_id": str(uuid.uuid4()),
        "user_id": user_id,
        "amount": tx_amount,
        "location_risk": location_risk,
        "timestamp": datetime.utcnow().isoformat()
    }
    
    try:
        # Push the record to Kinesis
        response = kinesis_client.put_record(
            StreamName=STREAM_NAME,
            Data=json.dumps(event_payload),
            PartitionKey=user_id 
        )
        st.success(f"✅ Event streamed successfully! Shard ID: {response['ShardId']}")
        st.json(event_payload)
    except Exception as e:
        st.error(f"❌ Failed to stream event: {str(e)}")
        st.info("Note: If the stream doesn't exist yet, this will fail. We will build it in the upcoming Terraform step.")