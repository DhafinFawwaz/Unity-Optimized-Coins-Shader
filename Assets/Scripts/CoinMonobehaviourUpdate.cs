using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoinMonobehaviourUpdate : MonoBehaviour
{
    [SerializeField] SpriteRenderer _coinSprite;
    [SerializeField] SpriteRenderer _shadowSprite;
    [SerializeField] Sprite[] _coinSprites;
    [SerializeField] float _jumpHeight = 1;
    [SerializeField] float _jumpDuration = 0.3f;
    [SerializeField] float _flipbookDuration = 0.2f;
    Transform _coinTrans;
    Vector2 _initialPosition;
    int _length;
    float _randomJumpDurationOffset;
    float _randomFlipbookOffset;
    void Start()
    {
        _coinTrans = _coinSprite.transform;
        _initialPosition = _coinTrans.position;
        _length = _coinSprites.Length;
        _randomJumpDurationOffset = Random.Range(0f, _jumpDuration);
        _randomFlipbookOffset = Random.value;
    }
    void Update()
    {
        _coinTrans.position = new Vector2(
            _initialPosition.x,
            _initialPosition.y +  _jumpHeight*JumpFunction( (Time.time + _randomJumpDurationOffset) /_jumpDuration) 
        );
        int currentIndex = Mathf.FloorToInt(Time.time * _length / _flipbookDuration + _length*_randomFlipbookOffset) % _length;
        _coinSprite.sprite = _coinSprites[currentIndex];
        _shadowSprite.sprite = _coinSprites[currentIndex];
    }

    float JumpFunction(float x)
    => Mathf.Abs(Mathf.Sin(Mathf.PI * x));
}
