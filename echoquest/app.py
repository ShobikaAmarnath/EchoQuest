from flask import Flask, request, jsonify
from transformers import pipeline

app = Flask(__name__)

# Load lightweight model (can switch to Gemma later)
qa = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    user_input = data.get("user_input")
    options = data.get("options")

    if not user_input or not options:
        return jsonify({"error": "Invalid input"}), 400

    result = qa(user_input, options)
    predicted = result["labels"][0]  # Most confident

    # Return just the option label
    return jsonify({"predicted_option": predicted})

if __name__ == "__main__":
    app.run(debug=True)
